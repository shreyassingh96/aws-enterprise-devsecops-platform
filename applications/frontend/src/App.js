import React, { useEffect, useState } from 'react';

function App() {
  const [data, setData] = useState(null);

  useEffect(() => {
    fetch('/api/data')
      .then(res => res.json())
      .then(resData => setData(resData))
      .catch(err => console.error("Failed to fetch data:", err));
  }, []);

  return (
    <div style={{ padding: '50px', fontFamily: 'Arial, sans-serif' }}>
      <h1>DevSecOps Platform Frontend</h1>
      <p>This is a production-grade React frontend served by Nginx.</p>
      <div style={{ marginTop: '20px', padding: '20px', background: '#f4f4f4', borderRadius: '5px' }}>
        <h3>Backend Data:</h3>
        <pre>{data ? JSON.stringify(data, null, 2) : "Loading..."}</pre>
      </div>
    </div>
  );
}

export default App;
