require.config
  name: 'plasticine'
  paths:
    'crossroads'       : '../components/crossroads.js/dist/crossroads'
    'signals'          : '../components/crossroads.js/dev/lib/signals'
    'custom-sinon'     : '../components/custom_sinon'
  packages: [
    {
      name: 'lodash'
      location: '../components/lodash-amd/modern'
    }
  ]
