{
  inputs = {
    "babel.nvim" = {
      url = "github:acidsugarx/babel.nvim";
      flake = false;
    };
    "blink.cmp" = {
      url = "github:saghen/blink.cmp";
      flake = false;
    };
    "blink.lib" = {
      url = "github:saghen/blink.lib";
      flake = false;
    };
    catppuccin = {
      url = "github:catppuccin/nvim";
      flake = false;
    };
    "dropbar.nvim" = {
      url = "github:Bekaboo/dropbar.nvim";
      flake = false;
    };
    "fyler.nvim" = {
      url = "github:FylerOrg/fyler.nvim";
      flake = false;
    };
    "gitsigns.nvim" = {
      url = "github:lewis6991/gitsigns.nvim";
      flake = false;
    };
    indentify = {
      url = "github:d-itu/indentify";
      flake = false;
    };
    "kanagawa.nvim" = {
      url = "github:rebelot/kanagawa.nvim";
      flake = false;
    };
    lua-format = {
      url = "github:d-itu/lua-format";
      flake = false;
    };
    "mini.icons" = {
      url = "github:nvim-mini/mini.icons";
      flake = false;
    };
    "minuet-ai.nvim" = {
      url = "github:milanglacier/minuet-ai.nvim";
      flake = false;
    };
    nvim-autopairs = {
      url = "github:windwp/nvim-autopairs";
      flake = false;
    };
    nvim-surround = {
      url = "github:kylechui/nvim-surround";
      flake = false;
    };
    nvim-ts-autotag = {
      url = "github:windwp/nvim-ts-autotag";
      flake = false;
    };
    "render-markdown.nvim" = {
      url = "github:meanderingprogrammer/render-markdown.nvim";
      flake = false;
    };
    rose-pine = {
      url = "github:rose-pine/neovim";
      flake = false;
    };
    "which-key.nvim" = {
      url = "github:folke/which-key.nvim";
      flake = false;
    };
  };

  outputs = inputs: {
    overlays.default = prev: final: {
      papervim = prev.callPackage ./nix/papervim.nix { inherit inputs; };
      lua-format = prev.callPackage ./nix/lua-format.nix { src = inputs.lua-format; };
      blink-cmp-fuzzy = prev.callPackage ./nix/blink-cmp-fuzzy.nix { src = inputs."blink.cmp"; };
    };
  };
}
