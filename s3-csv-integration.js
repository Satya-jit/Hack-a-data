// Updated S3 Configuration for CSV format
const S3_CONFIG = {
  bucketName: 'prism-database-excel',
  region: 'us-east-1',
  fileName: 'prism-data.csv', // Change to CSV
  get url() {
    return `https://${this.bucketName}.s3.${this.region}.amazonaws.com/${encodeURIComponent(this.fileName)}`;
  }
};

// Function to parse CSV data
function parseCSV(csvText) {
  const lines = csvText.split('\n').filter(line => line.trim());
  const headers = lines[0].split(',').map(h => h.trim().replace(/"/g, ''));
  
  const data = lines.slice(1).map(line => {
    const values = [];
    let current = '';
    let inQuotes = false;
    
    for (let i = 0; i < line.length; i++) {
      const char = line[i];
      if (char === '"') {
        inQuotes = !inQuotes;
      } else if (char === ',' && !inQuotes) {
        values.push(current.trim());
        current = '';
      } else {
        current += char;
      }
    }
    values.push(current.trim());
    
    const obj = {};
    headers.forEach((header, index) => {
      obj[header] = values[index] || '';
    });
    return obj;
  });
  
  return data;
}

// Updated fetch function for CSV
async function fetchDataFromS3() {
  try {
    console.log('🔄 Fetching CSV data from S3:', S3_CONFIG.url);
    
    const response = await fetch(S3_CONFIG.url, {
      method: 'GET',
      headers: {
        'Accept': 'text/csv'
      }
    });

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status} - ${response.statusText}`);
    }

    const csvText = await response.text();
    const formattedData = parseCSV(csvText);

    console.log(`✅ Successfully loaded ${formattedData.length} records from S3 CSV`);
    return formattedData;
    
  } catch (error) {
    console.error('❌ Error fetching CSV data from S3:', error);
    throw error;
  }
}