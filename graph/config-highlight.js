{
  node: {
    caption: ['display_label'],
    defaultIcon: false,
    color: '@color',
    size: '@size',
    onClick: (n) => {
      blitzboard.pathSrc = n.id;
      pathSourceNode.textContent = `${n.id}`;
      pathArrow.textContent = '--->';
      pathTargetNode.textContent = '';
      while (pathNodeList.firstChild) {
        pathNodeList.removeChild(pathNodeList.firstChild);
      }
    },
    onHover: (n) => {
      if (blitzboard.pathSrc && pathList[blitzboard.pathSrc] && pathList[blitzboard.pathSrc][n.id]) {
        pathTargetNode.textContent = '' + n.id;
        let edgeIds = [];
        while (pathNodeList.firstChild) {
          pathNodeList.removeChild(pathNodeList.firstChild);
        }
        pathList[blitzboard.pathSrc][n.id].forEach((path) => {
          const child = document.createElement('div');
          pathNodeList.appendChild(child);
          child.textContent = `${blitzboard.pathSrc}`;
          for (let i = 0; i < path.length - 1; i++) {
            if (blitzboard.hasEdge(path[i], path[i+1])) {
              edgeIds.push(`${path[i]}-${path[i+1]}`);
              child.textContent += ` -> ${path[i+1]}`;
            } else if (blitzboard.hasEdge(path[i+1], path[i])) {
              edgeIds.push(`${path[i+1]}-${path[i]}`);
              child.textContent += ` <- ${path[i+1]}`;
            }
          }
        });
        blitzboard.network.setSelection({
          nodes: [ blitzboard.pathSrc ],
          edges: edgeIds
        });
      }
    },
  },
  edge: {
    caption: [],
    width: 2.7,
    color: '@color',
    opacity: 0.6,
  },
  layout: 'default',
  extraOptions: {
    physics: {
      stabilization: true
    },
    interaction: {
      selectConnectedEdges: false,
      hover: true,
      hoverConnectedEdges: false
    }
  }
}
