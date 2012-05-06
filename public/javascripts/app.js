(function(/*! Brunch !*/) {
  'use strict';

  if (!this.require) {
    var modules = {};
    var cache = {};
    var __hasProp = ({}).hasOwnProperty;

    var expand = function(root, name) {
      var results = [], parts, part;
      if (/^\.\.?(\/|$)/.test(name)) {
        parts = [root, name].join('/').split('/');
      } else {
        parts = name.split('/');
      }
      for (var i = 0, length = parts.length; i < length; i++) {
        part = parts[i];
        if (part == '..') {
          results.pop();
        } else if (part != '.' && part != '') {
          results.push(part);
        }
      }
      return results.join('/');
    };

    var getFullPath = function(path, fromCache) {
      var store = fromCache ? cache : modules;
      var dirIndex;
      if (__hasProp.call(store, path)) return path;
      dirIndex = expand(path, './index');
      if (__hasProp.call(store, dirIndex)) return dirIndex;
    };
    
    var cacheModule = function(name, path, contentFn) {
      var module = {id: path, exports: {}};
      try {
        cache[path] = module.exports;
        contentFn(module.exports, function(name) {
          return require(name, dirname(path));
        }, module);
        cache[path] = module.exports;
      } catch (err) {
        delete cache[path];
        throw err;
      }
      return cache[path];
    };

    var require = function(name, root) {
      var path = expand(root, name);
      var fullPath;

      if (fullPath = getFullPath(path, true)) {
        return cache[fullPath];
      } else if (fullPath = getFullPath(path, false)) {
        return cacheModule(name, fullPath, modules[fullPath]);
      } else {
        throw new Error("Cannot find module '" + name + "'");
      }
    };

    var dirname = function(path) {
      return path.split('/').slice(0, -1).join('/');
    };

    this.require = function(name) {
      return require(name, '');
    };

    this.require.brunch = true;
    this.require.define = function(bundle) {
      for (var key in bundle) {
        if (__hasProp.call(bundle, key)) {
          modules[key] = bundle[key];
        }
      }
    };
  }
}).call(this);
(this.require.define({
  "application": function(exports, require, module) {
    (function() {
  var AirCell, Application, Cell, Directions, EarthCell, Grid, HardEarthCell, MetalCell, Miner, Position, Router, SoftEarthCell, World, app, cellSize, gridHeight, gridWidth, viewportHeight, viewportWidth,
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  Router = require('lib/router');

  gridWidth = 9;

  gridHeight = 6;

  viewportWidth = 9;

  viewportHeight = 7;

  cellSize = 40;

  Directions = (function() {

    function Directions(up, right, down, left) {
      this.up = up;
      this.right = right;
      this.down = down;
      this.left = left;
    }

    return Directions;

  })();

  Position = (function() {

    function Position(i, j) {
      this.i = i;
      this.j = j;
    }

    Position.prototype.x = function() {
      return this.i * cellSize;
    };

    Position.prototype.y = function() {
      return this.j * cellSize;
    };

    Position.prototype.moveUp = function() {
      return this.j--;
    };

    Position.prototype.moveDown = function() {
      return this.j++;
    };

    Position.prototype.moveLeft = function() {
      return this.i--;
    };

    Position.prototype.moveRight = function() {
      return this.i++;
    };

    Position.prototype.move = function(dir) {
      switch (dir) {
        case 'up':
          return this.moveUp();
        case 'down':
          return this.moveDown();
        case 'left':
          return this.moveLeft();
        case 'right':
          return this.moveRight();
      }
    };

    return Position;

  })();

  Cell = (function() {

    function Cell(pos) {
      this.pos = pos;
    }

    Cell.prototype.draw = function(paper) {
      return this.rect = paper.rect(this.pos.x(), this.pos.y(), cellSize, cellSize);
    };

    return Cell;

  })();

  AirCell = (function(_super) {

    __extends(AirCell, _super);

    function AirCell() {
      AirCell.__super__.constructor.apply(this, arguments);
    }

    AirCell.prototype.draw = function(paper) {
      AirCell.__super__.draw.call(this, paper);
      return this.rect.attr('fill', '#3090C7');
    };

    return AirCell;

  })(Cell);

  SoftEarthCell = (function(_super) {

    __extends(SoftEarthCell, _super);

    function SoftEarthCell() {
      SoftEarthCell.__super__.constructor.apply(this, arguments);
    }

    SoftEarthCell.prototype.draw = function(paper) {
      SoftEarthCell.__super__.draw.call(this, paper);
      return this.rect.attr('fill', '#B99B64');
    };

    return SoftEarthCell;

  })(Cell);

  EarthCell = (function(_super) {

    __extends(EarthCell, _super);

    function EarthCell() {
      EarthCell.__super__.constructor.apply(this, arguments);
    }

    EarthCell.prototype.draw = function(paper) {
      EarthCell.__super__.draw.call(this, paper);
      return this.rect.attr('fill', '#9B8569');
    };

    return EarthCell;

  })(Cell);

  HardEarthCell = (function(_super) {

    __extends(HardEarthCell, _super);

    function HardEarthCell() {
      HardEarthCell.__super__.constructor.apply(this, arguments);
    }

    HardEarthCell.prototype.draw = function(paper) {
      HardEarthCell.__super__.draw.call(this, paper);
      return this.rect.attr('fill', '#786B66');
    };

    return HardEarthCell;

  })(Cell);

  MetalCell = (function(_super) {

    __extends(MetalCell, _super);

    function MetalCell() {
      MetalCell.__super__.constructor.apply(this, arguments);
    }

    MetalCell.prototype.draw = function(paper) {
      MetalCell.__super__.draw.call(this, paper);
      return this.rect.attr('fill', '#784F5F');
    };

    return MetalCell;

  })(Cell);

  Grid = (function() {

    function Grid(width, height) {
      this.width = width;
      this.height = height;
      this.bounds = new Position(this.width, this.height);
      this.cells = [];
    }

    Grid.prototype.indexToPosition = function(k) {
      var i, j;
      j = Math.floor(k / this.width);
      i = k - j * this.width;
      return new Position(i, j);
    };

    Grid.prototype.positionToIndex = function(pos) {
      return pos.j * this.width + pos.i;
    };

    Grid.prototype.near = function(pos) {
      var k;
      k = this.positionToIndex(pos);
      return new Directions(this.cells[k - this.width], this.cells[k + 1], this.cells[k + this.width], this.cells[k - 1]);
    };

    Grid.prototype.setCell = function(c) {
      return this.cells[this.positionToIndex(c.pos)] = c;
    };

    Grid.prototype.parse = function(grid) {
      var k, _ref, _results;
      if (grid.length !== this.width * this.height) new Error('Invalid grid size');
      _results = [];
      for (k = 0, _ref = grid.length; 0 <= _ref ? k < _ref : k > _ref; 0 <= _ref ? k++ : k--) {
        switch (grid[k]) {
          case 'a':
            _results.push(this.setCell(new AirCell(this.indexToPosition(k))));
            break;
          case 's':
            _results.push(this.setCell(new SoftEarthCell(this.indexToPosition(k))));
            break;
          case 'e':
            _results.push(this.setCell(new EarthCell(this.indexToPosition(k))));
            break;
          case 'h':
            _results.push(this.setCell(new HardEarthCell(this.indexToPosition(k))));
            break;
          case 'm':
            _results.push(this.setCell(new MetalCell(this.indexToPosition(k))));
            break;
          default:
            _results.push(void 0);
        }
      }
      return _results;
    };

    Grid.prototype.draw = function(paper) {
      var _this = this;
      return this.cells.map(function(c) {
        return c.draw(paper);
      });
    };

    return Grid;

  })();

  Miner = (function() {

    function Miner(pos, world) {
      this.pos = pos;
      this.world = world;
      this.world.players.push(this);
      this.acting = false;
    }

    Miner.prototype.draw = function(paper) {
      var a;
      a = this.circleAttrs();
      this.circle = paper.circle(a.x, a.y, a.h);
      return this.circle.attr('fill', '#f00');
    };

    Miner.prototype.circleAttrs = function() {
      var h, v;
      h = cellSize / 2;
      return v = {
        h: h,
        x: this.pos.x() + h,
        y: this.pos.y() + h
      };
    };

    Miner.prototype.act = function(dir) {
      var a, attr,
        _this = this;
      if (!this.acting) {
        this.acting = true;
        attr = this.circle.attr();
        this.pos.move(dir);
        a = this.circleAttrs();
        attr.cx = a.x;
        attr.cy = a.y;
        return this.circle.animate(attr, 200, '<>', function() {
          return _this.acting = false;
        });
      }
    };

    Miner.prototype.handleKeydown = function(kc) {
      switch (kc) {
        case 38:
          return this.act('up');
        case 40:
          return this.act('down');
        case 37:
          return this.act('left');
        case 39:
          return this.act('right');
      }
    };

    return Miner;

  })();

  World = (function() {

    function World(grid) {
      this.grid = grid;
      this.players = [];
    }

    return World;

  })();

  Application = (function() {

    function Application() {}

    Application.prototype.player = void 0;

    Application.prototype.initialize = function() {
      var sample_grid, viewportBounds;
      viewportBounds = new Position(viewportWidth, viewportHeight);
      this.paper = Raphael("canvas", viewportBounds.x(), viewportBounds.y());
      this.world = new World(new Grid(gridWidth, gridHeight));
      sample_grid = ['a', 'a', 'a', 'a', 'a', 'a', 'a', 'a', 'a', 's', 's', 's', 's', 's', 's', 's', 's', 's', 'e', 'e', 's', 'h', 's', 'e', 'h', 'h', 's', 'h', 'e', 'e', 'h', 'e', 'e', 'e', 'h', 'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e', 'm', 'm', 'm', 'e', 'e', 'm', 'm', 'e', 'e', 'h', 'h', 'm', 'e', 'e', 'h', 'm', 'e', 'e'];
      this.world.grid.parse(sample_grid);
      this.world.grid.draw(this.paper);
      return this.joinGame();
    };

    Application.prototype.joinGame = function() {
      var _this = this;
      this.player = new Miner(new Position(3, 0), this.world);
      this.player.draw(this.paper);
      return $(document).keydown(function(kde) {
        return _this.player.handleKeydown(kde.keyCode);
      });
    };

    return Application;

  })();

  app = new Application;

  module.exports = app;

}).call(this);

  }
}));
(this.require.define({
  "initialize": function(exports, require, module) {
    (function() {
  var application;

  application = require('application');

  $(function() {
    var _ref;
    application.initialize();
    return (_ref = Backbone.history) != null ? _ref.start() : void 0;
  });

}).call(this);

  }
}));
(this.require.define({
  "lib/router": function(exports, require, module) {
    (function() {
  var Router, application,
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  application = require('application');

  module.exports = Router = (function(_super) {

    __extends(Router, _super);

    function Router() {
      Router.__super__.constructor.apply(this, arguments);
    }

    return Router;

  })(Backbone.Router);

}).call(this);

  }
}));
(this.require.define({
  "lib/view_helper": function(exports, require, module) {
    (function() {



}).call(this);

  }
}));
(this.require.define({
  "models/collection": function(exports, require, module) {
    (function() {
  var Collection,
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  module.exports = Collection = (function(_super) {

    __extends(Collection, _super);

    function Collection() {
      Collection.__super__.constructor.apply(this, arguments);
    }

    return Collection;

  })(Backbone.Collection);

}).call(this);

  }
}));
(this.require.define({
  "models/model": function(exports, require, module) {
    (function() {
  var Model,
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  module.exports = Model = (function(_super) {

    __extends(Model, _super);

    function Model() {
      Model.__super__.constructor.apply(this, arguments);
    }

    return Model;

  })(Backbone.Model);

}).call(this);

  }
}));
(this.require.define({
  "views/canvas_view": function(exports, require, module) {
    (function() {
  var CanvasView, app,
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  require('lib/view_helper');

  app = require('application');

  module.exports = CanvasView = (function(_super) {

    __extends(CanvasView, _super);

    function CanvasView(options) {
      if (options == null) options = {};
      CanvasView.__super__.constructor.call(this, options);
      this.paper = app.paper;
    }

    return CanvasView;

  })(Backbone.View);

}).call(this);

  }
}));
(this.require.define({
  "views/miner": function(exports, require, module) {
    (function() {
  var MinerView, app,
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  app = require('application');

  module.exports = MinerView = (function(_super) {

    __extends(MinerView, _super);

    function MinerView(options) {
      if (options == null) options = {};
      MinerView.__super__.constructor.call(this, options);
      this.paper = app.paper;
    }

    return MinerView;

  })(Backbone.View);

  ({
    render: function() {
      this.circle = this.paper.circle(50, 40, 10);
      return this.circle("fill", "#f00");
    }
  });

}).call(this);

  }
}));
(this.require.define({
  "views/templates/home": function(exports, require, module) {
    module.exports = Handlebars.template(function (Handlebars,depth0,helpers,partials,data) {
  helpers = helpers || Handlebars.helpers;
  var foundHelper, self=this;


  return "<div id=\"content\">\r\n  <h1>brunch</h1>\r\n  <h2>Welcome!</h2>\r\n  <ul>\r\n    <li><a href=\"http://brunch.readthedocs.org/\">Documentation</a></li>\r\n    <li><a href=\"https://github.com/brunch/brunch/issues\">Github Issues</a></li>\r\n    <li><a href=\"https://github.com/brunch/twitter\">Twitter Example App</a></li>\r\n    <li><a href=\"https://github.com/brunch/todos\">Todos Example App</a></li>\r\n  </ul>\r\n</div>\r\n";});
  }
}));
(this.require.define({
  "views/view": function(exports, require, module) {
    (function() {
  var View,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  require('lib/view_helper');

  module.exports = View = (function(_super) {

    __extends(View, _super);

    function View() {
      this.render = __bind(this.render, this);
      View.__super__.constructor.apply(this, arguments);
    }

    View.prototype.template = function() {};

    View.prototype.getRenderData = function() {};

    View.prototype.render = function() {
      this.$el.html(this.template(this.getRenderData()));
      this.afterRender();
      return this;
    };

    View.prototype.afterRender = function() {};

    return View;

  })(Backbone.View);

}).call(this);

  }
}));
