require.config
  name: 'plasticine'
  paths:
    'crossroads'       : '../components/crossroads.js/dist/crossroads'
    'signals'          : '../components/crossroads.js/dev/lib/signals'
  packages: [
    {
      name: 'lodash'
      location: '../components/lodash-amd/modern'
    }
  ]
