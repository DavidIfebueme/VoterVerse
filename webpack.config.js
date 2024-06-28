const path = require('path');

module.exports = {
  entry: './app/static/js/generate_registration_proof.js',
  output: {
    filename: 'bundle.js',
    path: path.resolve(__dirname, 'app/static/js'),
  },
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader',
          options: {
            presets: ['@babel/preset-env'],
          },
        },
      },
      {
        test: /\.json$/,
        loader: 'json-loader',
        type: 'javascript/auto',
      },
    ],
  },
  resolve: {
    fallback: {
      "fs": false,
      "path": false,
      "crypto": false,
    },
  },
  watch: true,
};
