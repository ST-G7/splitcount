const sdk = require("node-appwrite");

/*
  'req' variable has:
    'headers' - object with request headers
    'payload' - request body data as a string
    'variables' - object with function variables

  'res' variable has:
    'send(text, status)' - function to return text response. Status code defaults to 200
    'json(obj, status)' - function to return JSON response. Status code defaults to 200

  If an error is thrown, a response with code 500 will be returned.
*/

module.exports = async function (req, res) {
  const client = new sdk.Client();
  const database = new sdk.Databases(client);

  if (
    !req.variables["APPWRITE_FUNCTION_ENDPOINT"] ||
    !req.variables["APPWRITE_FUNCTION_API_KEY"]
  ) {
    console.warn(
      "Environment variables are not set. Function cannot use Appwrite SDK."
    );
    throw new Error("Environment variables are missing.");
  } else {
    client
      .setEndpoint(req.variables["APPWRITE_FUNCTION_ENDPOINT"])
      .setProject(req.variables["APPWRITE_FUNCTION_PROJECT_ID"])
      .setKey(req.variables["APPWRITE_FUNCTION_API_KEY"])
      .setSelfSigned(true);
  }

  const databaseId = "642e85442ecb0146d94f";
  const groupCollectionId = "642e86754648f1898e7b";
  const transactionCollectionId = "64327dbba600a97fc0fa";

  const input = JSON.parse(req.payload);

  if (!input.groupId) {
    res.json(
      {
        error: "groupId request parameter is missing",
      },
      500
    );
    return;
  }

  const group = await database.getDocument(
    databaseId,
    groupCollectionId,
    input.groupId
  );

  const transactionResponse = await database.listDocuments(
    databaseId,
    transactionCollectionId,
    [sdk.Query.equal("group", input.groupId)]
  );

  const transactions = transactionResponse.documents;

  const saldos = {};

  for (const member of group.members) {
    saldos[member] = 0;
  }

  for (const t of transactions) {
    const usersCount = t.users?.length ?? 0;
    if (usersCount == 0) {
      continue;
    }
    const roundedAmount = Math.round(t.amount * 100) / 100;
    const costPerUser = Math.round((roundedAmount / usersCount) * 100) / 100;

    saldos[t.user] += roundedAmount;
    for (const other of t.users) {
      saldos[other] -= costPerUser;
    }
  }

  const saldosResponse = group.members.map((member) => ({
    name: member,
    saldo: saldos[member],
  }));

  res.json({
    saldos: saldosResponse
  });
};
