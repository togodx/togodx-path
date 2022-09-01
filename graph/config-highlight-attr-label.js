{
  node: {
    caption: ['id'],
    defaultIcon: false,
    color: '@color',
    size: '@size',
    shape: {
      attribute: 'star'
    },
    onClick: (n) => {
      if (pathList[n.id]) {
        blitzboard.pathSrc = n.id;
        blitzboard.network.setSelection({ nodes: [ n.id ] });
        pathNodeList.textContent = `${n.id} - (mouseover the other one)`;
      }
    },
    onHover: (n) => {
      if (blitzboard.pathSrc && pathList[blitzboard.pathSrc] && pathList[blitzboard.pathSrc][n.id]) {
        while (pathNodeList.firstChild) {
          pathNodeList.removeChild(pathNodeList.firstChild);
        }
        const edgeSet = new Set();
        const nodeSet = new Set([ blitzboard.pathSrc, n.id ]);
        pathList[blitzboard.pathSrc][n.id].forEach((path) => {
          const child = document.createElement('div');
          pathNodeList.appendChild(child);
          child.textContent = `${blitzboard.pathSrc}`;
          for (let i = 0; i < path.length - 1; i++) {
            if (blitzboard.hasEdge(path[i], path[i+1])) {
              edgeSet.add(`${path[i]}-${path[i+1]}`);
            }
            if (blitzboard.hasEdge(path[i+1], path[i])) {
              edgeSet.add(`${path[i+1]}-${path[i]}`);
            }
            child.textContent += ` - ${path[i+1]}`;
          }
        });
        blitzboard.network.setSelection({
          nodes: Array.from(nodeSet),
          edges: Array.from(edgeSet)
        });
      }
    },
    borderWidthSelected: 3,
  },
  edge: {
    caption: [],
    width: '@width',
    color: '@color',
    opacity: '@opacity',
    chosen: {
      "": {
        edge: (values, id, selected, hovering) => {
          if (selected) {
            values.color = blitzboard.edgeMap[id].properties.color[0];
            values.width = 7; // 5 + 2
            values.shadowSize = 9;
          }
        }
      }
    }
  },
  layout: 'default',
  style: "background: white;",
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
