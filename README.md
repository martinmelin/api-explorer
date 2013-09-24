# Tictail API Explorer
Tictail API Explorer is a native Tictail app for playing around with our API, and is available on the apps page of your Tictail developer account. The source code is provided here as an example on how you could build your own amazing native app on Tictail.

# Installing
First off, make sure you have both [Node.js](http://nodejs.org/download/) and [RubyGems](http://rubygems.org/pages/download) installed on your system, then run the following commands:
```
npm install -g bower grunt-cli
gem install compass
git clone git@github.com:tictail/api-explorer.git
cd api-explorer
npm install
bower install
```

# Running the app
Run the app with:
```
grunt server
```
This sets up a local server that takes care of compiling and serving assets, and live reloads the browser whenever a file is changed. If the port the server wants to run on is occupied, you can change it with:
```
PORT=9002 grunt server
```

# Building
To neatly minify and concatenate all assets, run:
```
grunt build
```

# License
See the LICENSE file.