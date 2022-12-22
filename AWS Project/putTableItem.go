package main

// Initialize a session that the SDK will use to load
// credentials from the shared credentials file ~/.aws/credentials
// and region from the shared configuration file ~/.aws/config.

import (
	"encoding/json"
	"net/http"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/dynamodb"
	"github.com/aws/aws-sdk-go/service/dynamodb/dynamodbattribute"

	"fmt"
	"log"
)



type FinalResultTableItem struct {

	Served 			int

	RiderID 		int
	RiderName		string
	
	DriverID		int
	DriverName		string
	
}

// global var
var finalResultTableItem = FinalResultTableItem{}
var counter = 0

func putItem(w http.ResponseWriter, req *http.Request) {

	// reply
	fmt.Fprintf(w, "OK")

	// decodes state from json as String
	json.NewDecoder(req.Body).Decode(&finalResultTableItem)


	// close connection
	req.Close = true


	// increment the number of matched requests
	counter += 1
	finalResultTableItem.Served  = counter

	// put new item into dynamodb
	PutItem("ResultsTable")

}

func PutItem(tableName string) {

	sess := session.Must(session.NewSessionWithOptions(session.Options{
		SharedConfigState: session.SharedConfigEnable,
	}))

	// Create DynamoDB client
	svc := dynamodb.New(sess)

	av, err := dynamodbattribute.MarshalMap(finalResultTableItem)
	if err != nil {
		log.Fatalf("Got error marshalling new movie item: %s", err)
	}

	input := &dynamodb.PutItemInput{
		Item:      av,
		TableName: aws.String(tableName),
	}

	_, err = svc.PutItem(input)
	if err != nil {
		log.Fatalf("Got error calling PutItem: %s", err)
	}
}

func main() {

	http.HandleFunc("/putTableItem", putItem)

	err := http.ListenAndServe("localhost:7777", nil)

	if err != nil {
		log.Fatal(err)
	}

	// DeleteItem(2, "TripRegistrations")
}




