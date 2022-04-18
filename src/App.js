import { useEffect, useState } from 'react';
import axios from 'axios';
import Tabs from './components/Tabs';
import ListView from './components/ListView';
import GridView from './components/GridView';
import './App.css';

const App = () => {
  const [herosData, setHerosData] = useState([]);

  useEffect(() => {
    const fetchData = async () => {
      const res = await axios.get('https://tppublic.blob.core.windows.net/test-data/super-heroes.json');
      setHerosData(res.data.map((hero) => ({
        id: hero.id, name: hero.name, realName: hero.biography['full-name'], url: hero.image?.url,
      })));
    }
    fetchData();
  }, []);
  // test ==
  return (
    <div>
      <Tabs>
        <div label="List View">
          <ListView data={herosData} />
        </div>
        <div label="Grid View">
          <GridView data={herosData} />
        </div>
      </Tabs>
    </div>
  );
}

export default App;
