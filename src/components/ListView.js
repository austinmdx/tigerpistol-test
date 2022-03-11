const ListView = ({ data }) => (
  <ul>
    { data.map(({ id }) => (
      <li key={id}>
        {id}  Hero Name (Real Name)
      </li>
    )) }
  </ul>
);

export default ListView;
