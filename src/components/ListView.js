const ListView = ({ data }) => (
  <ul>
    { data.map(({ id, name, realName }) => (
      <li key={id}>
        {id}  {name}({realName})
      </li>
    )) }
  </ul>
);

export default ListView;
