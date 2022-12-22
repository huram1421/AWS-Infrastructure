package main

// Initialize a session that the SDK will use to load
// credentials from the shared credentials file ~/.aws/credentials
// and region from the shared configuration file ~/.aws/config.

import (
	"encoding/json"
	"net/http"
	"strconv"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/dynamodb"
	"github.com/aws/aws-sdk-go/service/dynamodb/dynamodbattribute"

	"fmt"
	"log"
)


type GetUserJson struct {
	ID 		int
	Name	string
	Kind	string
	Src		string
	Dest	string
}

// global var
var getUserJson = GetUserJson{}

func getItem(w http.ResponseWriter, req *http.Request) {

	// decodes state from query as String
	partitionKey, _ := strconv.Atoi(req.URL.Query()["ID"][0])
	tableName := req.URL.Query()["tableName"][0]

	
	fmt.Println("first get")
	// Get from Data Base
	isItemFound := GetFromDynamoDB(partitionKey, tableName)


	// return lookUp result
	if isItemFound == true{
		lookUpReply, _ := json.Marshal(getUserJson)
		w.Write(lookUpReply)
	}

	fmt.Println("last get")

	// close connection
	req.Close = true

}

func GetFromDynamoDB(partitionKey int, tableName string) (isItemFound bool){


	sess := session.Must(session.NewSessionWithOptions(session.Options{
		SharedConfigState: session.SharedConfigEnable,
	}))

	// Create DynamoDB client
	svc := dynamodb.New(sess)

	result, err := svc.GetItem(&dynamodb.GetItemInput{
		TableName: aws.String(tableName),
		Key: map[string]*dynamodb.AttributeValue{
			"ID": {
				N: aws.String(strconv.Itoa(partitionKey)),
			},
		},
	})

	if err != nil {
		log.Fatalf("Got error calling GetItem: %s", err)
		return false
	}

	if result.Item == nil {
		fmt.Print("Connection is correct, but cound not find item!")
		return false
	}

	err = dynamodbattribute.UnmarshalMap(result.Item, &getUserJson)
	if err != nil {
		panic(fmt.Sprintf("Failed to unmarshal Record, %v", err))
		return false
	}

	// otherise
	return true

}

func main() {

	http.HandleFunc("/getTableItem", getItem)

	err := http.ListenAndServe("localhost:6666", nil)

	if err != nil {
		log.Fatal(err)
	}

}



