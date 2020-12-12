/*This is the lambda code used as inline document in terraform configuration*/
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