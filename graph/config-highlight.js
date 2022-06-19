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
      blitzboard.highlightNodePath(pathList[blitzboard.pathSrc][n.id]);
    },
  },
  edge: {
    caption: [],
    width: 4,
    color: '@color',
    opacity: 0.6,
  },
  layout: 'default',
  extraOptions: {
    physics: {
      stabilization: true
    }
  }
}
