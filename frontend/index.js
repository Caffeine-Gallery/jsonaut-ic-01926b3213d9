import { backend } from "declarations/backend";

document.addEventListener('DOMContentLoaded', () => {
  document.getElementById("jsonForm").addEventListener("submit", async (e) => {
    e.preventDefault();
    const json = document.getElementById("jsonInput").value;
    try {
      await backend.setJSON(json);
      document.getElementById("result").innerText = "JSON set successfully";
      updateStoredJSON();
    } catch (error) {
      console.error("Error setting JSON:", error);
      document.getElementById("result").innerText = `Error: ${error.message || 'Unknown error occurred'}`;
    }
  });

  document.getElementById("pathForm").addEventListener("submit", async (e) => {
    e.preventDefault();
    const path = document.getElementById("pathInput").value;
    try {
      const result = await backend.accessJSONPath(path);
      document.getElementById("result").innerText = `Result: ${result}`;
    } catch (error) {
      console.error("Error accessing JSON path:", error);
      document.getElementById("result").innerText = `Error: ${error.message || 'Unknown error occurred'}`;
    }
  });

  document.getElementById("getStoredJSON").addEventListener("click", updateStoredJSON);

  // Initialize with default JSON
  updateStoredJSON();
});

async function updateStoredJSON() {
  try {
    const storedJSON = await backend.getJSON();
    document.getElementById("storedJSON").innerText = storedJSON;
  } catch (error) {
    console.error("Error getting stored JSON:", error);
    document.getElementById("storedJSON").innerText = `Error: ${error.message || 'Unknown error occurred'}`;
  }
}

window.onerror = function(message, source, lineno, colno, error) {
  console.error("Global error:", message, source, lineno, colno, error);
  document.getElementById("result").innerText = `Global Error: ${message}`;
  return true;
};
