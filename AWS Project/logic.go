package main

import (
	"bytes"
	"fmt"
	"encoding/json"
	"io/ioutil"
	"log"
	"net/http"
	"strconv"
)

type LogicUserJson struct {
	ID 		int
	Kind   string
}

type DataBaseLookUpRiderJson struct {
	ID 		int
	Name	string
	Kind	string
	Src		string
	Dest	string
}

type DataBaseLookUpDriverJson struct {
	ID 		int
	Name	string
	Kind	string
	Src		string
	Dest	string
}

type FinalResultItem struct {
	RiderID 		int
	RiderName		string
	
	DriverID		int
	DriverName		string
}

// global var
var logicUserJson = LogicUserJson{}
var dataBaseLookUpRiderJson = DataBaseLookUpRiderJson{}
var dataBaseLookUpDriverJson = DataBaseLookUpRiderJson{}
var finalResultItem = FinalResultItem{}


// slices
var driverSlice = []int{}
var riderSlice = []int{}


func logic(w http.ResponseWriter, req *http.Request) {

	// Decodes json into structure variables
	json.NewDecoder(req.Body).Decode(&logicUserJson)

	fmt.Println("fist logic")

	// reply to caller
	fmt.Fprintf(w, "OK")

	// ================ Logic ================ //
	switch logicUserJson.Kind {
	case "D":

		driverSlice = append(driverSlice, logicUserJson.ID)
		
	case "R":

		riderSlice = append(riderSlice, logicUserJson.ID)

	}

	// ================ Algorithm ================ //

	nestedLoops:
	for r := 0; r < len(riderSlice); r++ {
		
		if len(driverSlice) != 0 {
			fmt.Println("entered logic if")
			// lookup from database
			LookUpRider(riderSlice[r])
		}

		for d := 0; d < len(driverSlice); d++ {

			// lookup from database
			LookUpDriver(driverSlice[d])

			if dataBaseLookUpRiderJson.Src == dataBaseLookUpDriverJson.Src && dataBaseLookUpRiderJson.Dest == dataBaseLookUpDriverJson.Dest {

				finalResultItem = FinalResultItem{
					RiderID: 		dataBaseLookUpRiderJson.ID,
					RiderName:		dataBaseLookUpRiderJson.Name,
					
					DriverID: 		dataBaseLookUpDriverJson.ID,
					DriverName:		dataBaseLookUpDriverJson.Name}

				// send to data base
				PutMatchedIntoFinalTable()

				// delete from sliece
				driverSlice = remove(driverSlice, d)
				riderSlice = remove(riderSlice, r)

				// delete corresponding items from data base from data base
				deleteItem(dataBaseLookUpDriverJson.ID, "DriverTable")
				deleteItem(dataBaseLookUpRiderJson.ID, "RiderTable")

				// exit nestedloops
				break nestedLoops
			}


		}


	}

	// close connection
	req.Close = true

}

func remove(s []int, i int) ([]int) {
    s[i] = s[len(s)-1]
    return s[:len(s)-1]
}


func LookUpDriver(ID int) {

	// ================ Lookup ================ // 
	request, error := http.Get("http://localhost:6666/getTableItem?ID=" + strconv.Itoa(ID) + "&tableName=DriverTable")
	defer request.Body.Close()
	body, _ := ioutil.ReadAll(request.Body)
	json.Unmarshal(body, &dataBaseLookUpDriverJson)

	if error != nil {
		panic(error)
	}

}

func LookUpRider(ID int) {

	// ================ Lookup ================ // 
	request, error := http.Get("http://localhost:6666/getTableItem?ID=" + strconv.Itoa(ID) + "&tableName=RiderTable")
	defer request.Body.Close()
	body, _ := ioutil.ReadAll(request.Body)
	json.Unmarshal(body, &dataBaseLookUpRiderJson)

	if error != nil {
		panic(error)
	}

}


func PutMatchedIntoFinalTable () {

	// encodes json into bytes
	finalResultItem, _ := json.Marshal(&finalResultItem)

	// HTTP POST Request
	request, error := http.NewRequest("POST", "http://localhost:7777/putTableItem", bytes.NewBuffer(finalResultItem))
	request.Header.Set("Content-Type", "application/json; charset=UTF-8")
	client := &http.Client{}
	response, error := client.Do(request)
	client.CloseIdleConnections()

	if error != nil {
		panic(error)
	}

	defer response.Body.Close()
	body, _ := ioutil.ReadAll(response.Body)
	fmt.Println("response Body:", string(body))
}

func deleteItem(ID int, tableName string) {

	// HTTP POST Request
	request, error := http.NewRequest("POST", "http://localhost:5555/deleteTableItem?ID=" + strconv.Itoa(ID) + "&tableName=" + tableName, nil)
	request.Header.Set("Content-Type", "application/json; charset=UTF-8")
	client := &http.Client{}
	response, error := client.Do(request)
	client.CloseIdleConnections()

	if error != nil {
		panic(error)
	}

	defer response.Body.Close()
	body, _ := ioutil.ReadAll(response.Body)
	fmt.Println("response Body:", string(body))
}



func main() {

	http.HandleFunc("/logic", logic)

	err := http.ListenAndServe(":8888", nil)

	if err != nil {
		log.Fatal(err)
	}

}
