import Card from './Card';
import './grid-view.css'

const GridView = ({ data }) => {
  return (
    <div className="grid-view">
      { data.map(({ id, url, name }) => (<Card key={id} url={url} name={name} />)) }
    </div>
  )
}

export default GridView;
