import json from 'body-parser';
import { readTasks, writeTasks } from './fileReadWrite.js';
import express from 'express';
import fs from 'fs';


const app = express()




app.use(express.json())

app.get('/get-task', (req, res) => {

    const tasks = readTasks()

    res.json(tasks)
})

app.post('/add-task', (req, res) => {
    const tasks = readTasks()
    const task = req.body;
    // console.log(req.body.id);
    task.isComplete = false

    task.id = (tasks.length + Math.random() * 10).toString().replace('.', '').toString();
    tasks.push(task)
    writeTasks(tasks)
    res.status(201).json(task)
})

app.put('/toggleComplete/:id', (req, res) => {
    const tasks = readTasks()
    const id = req.params.id
    const task = tasks.find(t => id == t.id)
    if (task) {
        task.isComplete = !task.isComplete
        writeTasks(tasks)
        res.json(task)
    } else {
        res.status(404).json({ message: "Task not found" })
    }
})

app.delete('/delete-task/:id', (req, res) => {
    const tasks = readTasks()
    const id = req.params.id
    const index = tasks.findIndex(i => i.id == id)
    if (index !== -1) {
        tasks.splice(index, 1)
        writeTasks(tasks)
        res.json({ message: "Task Deleted" })
    } else {
        res.status(404).json({ message: "Task not found" })
    }
})


app.listen(8000, () => console.log("Server up!!! | Listening on http://localhost:8000"))
