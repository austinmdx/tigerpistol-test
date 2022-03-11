const Tab = ({ activeTab, label, onClick }) => (
  <li
    className={`tab-list-item${activeTab === label ? ' tab-list-active' : ''}`}
    onClick={() => onClick(label)}
  >
    {label}
  </li>
);

export default Tab;
