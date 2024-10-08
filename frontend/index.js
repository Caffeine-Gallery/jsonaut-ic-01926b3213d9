import { backend } from "declarations/backend";

document.getElementById("jsonForm").addEventListener("submit", async (e) => {
  e.preventDefault();
  const json = document.getElementById("jsonInput").value;
  try {
    await backend.setJSON(json);
    document.getElementById("result").innerText = "JSON set successfully";
  } catch (error) {
    document.getElementById("result").innerText = `Error: ${error.message}`;
  }
});

document.getElementById("pathForm").addEventListener("submit", async (e) => {
  e.preventDefault();
  const path = document.getElementById("pathInput").value;
  try {
    const result = await backend.accessJSONPath(path);
    document.getElementById("result").innerText = `Result: ${result}`;
  } catch (error) {
    document.getElementById("result").innerText = `Error: ${error.message}`;
  }
});

document.getElementById("getStoredJSON").addEventListener("click", async () => {
  try {
    const storedJSON = await backend.getJSON();
    document.getElementById("storedJSON").innerText = storedJSON;
  } catch (error) {
    document.getElementById("storedJSON").innerText = `Error: ${error.message}`;
  }
});
