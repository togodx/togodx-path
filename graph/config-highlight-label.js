{
  node: {
    caption: ['display_label'],
    defaultIcon: false,
    color: '@color',
    size: '@size',
    onClick: (n) => {
      blitzboard.pathSrc = n.id;
    },
    onHover: (n) => {
      if (blitzboard.pathSrc && pathList[blitzboard.pathSrc] && pathList[blitzboard.pathSrc][n.id]) {
        let edgeIds = [];
        pathList[blitzboard.pathSrc][n.id].forEach((path) => {
          for (let i = 0; i < path.length - 1; i++) {
            if (blitzboard.hasEdge(path[i], path[i+1])) {
              edgeIds.push(`${path[i]}-${path[i+1]}`);
            } else if (blitzboard.hasEdge(path[i+1], path[i])) {
              edgeIds.push(`${path[i+1]}-${path[i]}`);
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
    caption: ['display_label'],
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
