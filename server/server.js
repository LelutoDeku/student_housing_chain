const express = require("express");
const cors=require('cors');
const app = express();
const bodyParser=require('body-parser')
const mongoose=require('mongoose');
const toDatabase=require('./addData');
const schema=require('./schema');

app.use(cors());
app.use(bodyParser.json());
const db="mongodb+srv://admin:admin12345@cluster0.mitzpwb.mongodb.net/shc?retryWrites=true&w=majority&appName=AtlasApp";

const shcModel=new mongoose.model('organization',new mongoose.Schema(schema.shcSchema()))

app.post("/setConnection",(req,res)=>{
    console.log("connection here...");
})
mongoose.connect(db
).then(
    ()=> console.log("Connection successful...")
).catch(
    err => console.log(`Error Occured -> ${err}`)
)

app.post("/getNewOrg",(req,res) => {
    console.log(req.body);
    const onDatabase=toDatabase.addData(db,req.body,shcModel);
    console.log("server...");
    console.log(onDatabase);
    res.send({...onDatabase});
})


app.listen(5000, ()=>{
    console.log("server started on port 5000");
});