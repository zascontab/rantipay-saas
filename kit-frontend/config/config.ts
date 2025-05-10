// https://umijs.org/config/
import { defineConfig } from '@umijs/max';
import defaultSettings from './defaultSettings';
import proxy from './proxy';
import routes from './routes';

const { REACT_APP_ENV } = process.env;

export default defineConfig({
  hash: true,
  antd: {},
  request: {},
  initialState: {},
  model: {},
  layout: {
    // https://umijs.org/zh-CN/plugins/plugin-layout
    locale: true,
    siderWidth: 150,
    ...defaultSettings,
  },
  /**
   * @name moment2dayjs 插件
   * @description 将项目中的 moment 替换为 dayjs
   * @doc https://umijs.org/docs/max/moment2dayjs
   */
  moment2dayjs: {
    preset: 'antd',
    plugins: ['duration'],
  },
  // https://umijs.org/zh-CN/plugins/plugin-locale
  locale: {
    // default zh-CN
    default: 'zh-CN',
    title: true,
    antd: true,
    // default true, when it is true, will use `navigator.language` overwrite default
    baseNavigator: true,
  },

  targets: {},
  // umi routes: https://umijs.org/docs/routing
  routes: routes(),
  access: {},
  // Theme for antd: https://ant.design/docs/react/customize-theme-cn
  theme: {
    // 如果不想要 configProvide 动态设置主题需要把这个设置为 default
    // 只有设置为 variable， 才能使用 configProvide 动态设置主色调
    // https://ant.design/docs/react/customize-theme-variable-cn
    'root-entry-name': 'variable',
  },
  ignoreMomentLocale: true,
  proxy: proxy(REACT_APP_ENV)[REACT_APP_ENV as keyof typeof proxy],
  manifest: {
    basePath: '/',
  },
  monorepoRedirect: { srcDir: ['.', 'src'], peerDeps: true },
  // Fast Refresh 热更新
  fastRefresh: true,
  headScripts: [
    // 解决首次加载时白屏的问题
    { src: '/scripts/loading.js', async: true },
  ],
  presets: ['umi-presets-pro'],
  define: {
    BASE_URL: REACT_APP_ENV == 'dev' ? '/basic-api' : '',
  },
  qiankun: {
    master: {},
  },
  mfsu: {
    strategy: 'normal',
  },
});
