/** @type {import('next').NextConfig} */
const nextConfig = {
  webpack: (config, { isServer }) => {
    config.resolve.fallback = {
      ...config.resolve.fallback,
      __dirname: false,
      __filename: false,
      path: false,
      fs: false,
    };
    
    // Add a global __dirname polyfill
    config.plugins = [
      ...config.plugins,
      {
        apply: (compiler) => {
          compiler.hooks.beforeCompile.tap('DirnamePlugin', () => {
            global.__dirname = '/';
            global.__filename = 'app.js';
          });
        },
      },
    ];
    
    return config;
  },
  async headers() {
    return [
      {
        source: '/api/:path*',
        headers: [
          { key: 'Access-Control-Allow-Origin', value: '*' },
          { key: 'Access-Control-Allow-Methods', value: 'GET,POST,PUT,PATCH,DELETE,OPTIONS' },
          { key: 'Access-Control-Allow-Headers', value: 'Content-Type, Authorization' },
        ],
      },
    ];
  },
};

export default nextConfig;
