
# DynamoDB Table
resource "aws_dynamodb_table" "RiderTable" {

    name           = "RiderTable"
    billing_mode   = "PAY_PER_REQUEST"

    # partition key
    hash_key       = "ID" # partition key

    # These attribute blocks are not defining which attributes you can use in your application.
    # They are defining Primary key.
    attribute {
        name = "ID"
        type = "N"
    }

    ttl {
        attribute_name = "TimeToExist"
        enabled        = false
    }
}


# DynamoDB Table
resource "aws_dynamodb_table" "DriverTable" {

    name           = "DriverTable"
    billing_mode   = "PAY_PER_REQUEST"

    # partition key
    hash_key       = "ID" # partition key

    # These attribute blocks are not defining which attributes you can use in your application.
    # They are defining Primary key.
    attribute {
        name = "ID"
        type = "N"
    }

    ttl {
        attribute_name = "TimeToExist"
        enabled        = false
    }
}

# DynamoDB Table
resource "aws_dynamodb_table" "ResultTable" {

    name           = "ResultsTable"
    billing_mode   = "PAY_PER_REQUEST"

    # partition key
    hash_key       = "Served" 

    # These attribute blocks are not defining which attributes you can use in your application.
    # They are defining Primary key.
    attribute {
        name = "Served"
        type = "N"
    }

    ttl {
        attribute_name = "TimeToExist"
        enabled        = false
    }
}


