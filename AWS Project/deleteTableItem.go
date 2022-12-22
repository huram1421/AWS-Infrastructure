package main

import (
	"net/http"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/dynamodb"
	
	"log"
	"strconv"
)


func DeleteItem(w http.ResponseWriter, req *http.Request) {

	// decodes state from query as String
	partitionKey, _ := strconv.Atoi(req.URL.Query()["ID"][0])
	tableName := req.URL.Query()["tableName"][0]

	// close connection
	req.Close = true


	// delete item in Data Base
	DeleteTableItem(partitionKey, tableName)
}


func DeleteTableItem(partitionKey int, tableName string){

	// Initialize a session that the SDK will use to load
	// credentials from the shared credentials file ~/.aws/credentials
	// and region from the shared configuration file ~/.aws/config.
	sess := session.Must(session.NewSessionWithOptions(session.Options{
		SharedConfigState: session.SharedConfigEnable,
	}))

	// Create DynamoDB client
	svc := dynamodb.New(sess)

	input := &dynamodb.DeleteItemInput{
		Key: map[string]*dynamodb.AttributeValue{
			"ID": {
				N: aws.String(strconv.Itoa(partitionKey)),
			},
		},
		TableName: aws.String(tableName),
	}

	_, err := svc.DeleteItem(input)

	if err != nil {
		log.Fatalf("Got error calling DeleteItem: %s", err)
	}

}

func main() {

	http.HandleFunc("/deleteTableItem", DeleteItem)

	err := http.ListenAndServe("localhost:5555", nil)

	if err != nil {
		log.Fatal(err)
	}
}