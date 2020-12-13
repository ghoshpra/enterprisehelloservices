/*terraform {
  required_providers {
    aws = "= 3.0"
  }
}*/

provider "aws" {
  region     = "us-west-2"
  access_key = "AKIAZUEY72MVGXA5J2OQ"
  secret_key = "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"
}

# This is for inline lamda code without S3 dependency
data "archive_file" "lambda_zip_inline" {
  type        = "zip"
  output_path = "/tmp/lambda_zip_inline.zip"
  source {
    content  = <<EOF

    module.exports.handler = async (event, context, callback) => {
      var res = "";
      const name =   event.queryStringParameters && event.queryStringParameters.name;
      if (name !== undefined && name !== null && name !== '') {
              res = "Hello " + name;
          } else {
              res = 'Hello World';
          }
      var response = {
          "statusCode": 200,
          "body": JSON.stringify(res),
          "isBase64Encoded": false
      };
	     callback(null, response);
    };
EOF
    filename = "welcomeApi.js"
  }
}

resource "aws_lambda_function" "enterprisegreetservices" {
   function_name = "helloWorld"

   filename         = data.archive_file.lambda_zip_inline.output_path
   runtime = "nodejs10.x"
   handler = "welcomeApi.handler"

   # "welcomeApi" is the filename within the zip file (welcomeApi.js) and "handler"
   # is the name of the property under which the handler function was
   # exported in that file.

   # To attach the VPC with Lambda
   role = aws_iam_role.lambda_exec.arn
   vpc_config {
    subnet_ids         = [aws_subnet.subnet_for_lambda.id]
    security_group_ids = [aws_security_group.sg_for_lambda.id]
  }

}

 # IAM role and policy.
resource "aws_iam_role" "lambda_exec" {
   name = "serverless_hello_lambda"
   assume_role_policy = <<EOF
{
     "Version": "2012-10-17",
     "Statement": [
       {
        "Action": "sts:AssumeRole",
        "Principal": {
        "Service": "lambda.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  }
EOF
}

# This is required as Lambda is going to be in a custom VPC. Otherwise lambda creation will fail
resource "aws_iam_role_policy_attachment" "AWSLambdaVPCAccessExecutionRole" {
    role       = aws_iam_role.lambda_exec.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_lambda_permission" "apigw" {
   statement_id  = "AllowAPIGatewayInvoke"
   action        = "lambda:InvokeFunction"
   function_name = aws_lambda_function.enterprisegreetservices.function_name
   principal     = "apigateway.amazonaws.com"

   # The "/*/*" is for accessing from any method on any resource
   # within the API Gateway REST API.
   source_arn = "${aws_api_gateway_rest_api.hello.execution_arn}/*/*"
}


# VPC, Subnets and SG configuration

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "subnet_for_lambda" {
  vpc_id            = aws_vpc.main.id
  availability_zone = "us-west-2a"
  cidr_block  = "10.0.1.0/24"
}

resource "aws_security_group" "sg_for_lambda" {
  vpc_id            = aws_vpc.main.id
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
