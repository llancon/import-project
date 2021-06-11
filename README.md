# import-project

The purpose of this project is to import records from a CSV files into an app by leveraging it's REST API. In aid of this small project it was helpful to leverage Google's Geocode API to help find coordinates and get accurate location details for the records imported. 
Dot-env gem was chosen to handle sensitive data needed to execute API calls. Other gems (json, csv) were also used to assist in creating JSON and to read from CSV file. HTTParty is used to build and execute the API calls as singletons. 



