import './card.css';

const Card = ({ url, name }) => (
  <div
    className="card"
    style={{ backgroundImage: `linear-gradient(rgb(0 0 0 / 2%), rgb(0 0 0 / 80%)), url(${url})` }}
  >
    <p className="title">{ name }</p>
  </div>
)

export default Card;
