import { backend } from 'declarations/backend';

const jsonInput = document.getElementById('jsonInput');
const setJSONButton = document.getElementById('setJSON');
const pathInput = document.getElementById('pathInput');
const accessPathButton = document.getElementById('accessPath');
const resultDiv = document.getElementById('result');

const exampleJSON = {
  "person": {
    "name": "John Doe",
    "age": 30,
    "address": {
      "street": "123 Main St",
      "city": "Anytown",
      "country": "USA"
    },
    "hobbies": ["reading", "swimming", "coding"],
    "education": [
      {
        "degree": "Bachelor's",
        "major": "Computer Science",
        "year": 2015
      },
      {
        "degree": "Master's",
        "major": "Data Science",
        "year": 2018
      }
    ]
  }
};

jsonInput.value = JSON.stringify(exampleJSON, null, 2);

setJSONButton.addEventListener('click', async () => {
  try {
    await backend.setJSON(jsonInput.value);
    resultDiv.textContent = 'JSON set successfully';
  } catch (error) {
    resultDiv.textContent = `Error: ${error.message}`;
  }
});

accessPathButton.addEventListener('click', async () => {
  const path = pathInput.value;
  try {
    const result = await backend.accessJSONPath(path);
    resultDiv.textContent = `Result: ${result}`;
  } catch (error) {
    resultDiv.textContent = `Error: ${error.message}`;
  }
});
