const path = require('path');

module.exports = {
  entry: {
    'js/search/app': './js/components/search/search.js.jsx',
    'js/grid/app': './js/components/grid/grid.js.jsx',
    'js/graph/app': './js/components/graph/main.js',
    'js/post/app': './js/components/post/post.js.jsx',
  },
  output: {
    path: path.resolve(__dirname, 'public'),
    publicPath: './public',
    filename: '[name].js'
  },
  module: {
    loaders: [
      { test: /\.js$/, loader: 'babel-loader', exclude: /node_modules/ },
      { test: /\.jsx$/, loader: 'babel-loader', exclude: /node_modules/ }
    ]
  }
};