import fs, { readFileSync } from 'fs';

const FILEPATH = './tasks.json'


function readTasks() {
    try {
        const data = readFileSync(FILEPATH, 'utf-8')
        return JSON.parse(data)
    } catch (error) {
        console.error('Error reading tasks:', error);
        return [];
    }
}


function writeTasks(tasks) {
    try {
        fs.writeFileSync(FILEPATH, JSON.stringify(tasks, null, 2))
    } catch (error) {
        console.error('Error writing tasks:', error);

    }
}

export { readTasks, writeTasks };