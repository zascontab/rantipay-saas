﻿export default function getRoutes() {
  const extra = JSON.parse(process.env.EXTRA_ROUTES || '{}').routes || [];
  return [
    {
      path: '/user',
      layout: false,
      routes: [
        {
          name: 'login',
          path: '/user/login',
          component: './User/Login',
        },
        {
          name: 'register',
          path: '/user/register',
          component: './User/Register',
        },
        {
          name: 'consent',
          path: '/user/consent',
          component: './User/Consent',
        },
        {
          name: 'logout',
          path: '/user/logout',
          component: './User/Logout',
        },
        {
          component: './404',
        },
      ],
    },
    {
      path: '/admin',
      locale: 'admin.title',
      name: 'admin',
      icon: 'smile',
      routes: [
        {
          name: 'user',
          path: '/admin/users',
          component: './Admin/User',
        },
      ],
    },
    {
      path: '/sys',
      locale: 'sys.title',
      name: 'sys',
      icon: 'smile',
      routes: [
        {
          name: 'user',
          path: '/sys/users',
          component: './Sys/User',
        },
        {
          name: 'role',
          path: '/sys/roles',
          component: './Sys/Role',
        },
        {
          name: 'role-detail',
          path: '/sys/role/:id',
          component: './Sys/RoleDetail',
          hideInMenu: true,
        },
        {
          name: 'menu',
          path: '/sys/menus',
          component: './Sys/Menu',
        },
      ],
    },
    {
      path: '/oidc',
      icon: 'smile',
      routes: [
        {
          path: '/oidc/clients',
          component: './Oidc/Client',
        },
      ],
    },
    {
      path: '/saas',
      name: 'saas',
      icon: 'smile',
      routes: [
        {
          name: 'tenant',
          path: '/saas/tenants',
          component: './Saas/Tenant',
        },
        {
          name: 'plan',
          path: '/saas/plans',
          component: './Saas/Plan',
        },
      ],
    },
    {
      path: '/payment',
      name: 'payment',
      icon: 'smile',
      routes: [
        {
          name: 'payment.orders',
          path: '/payment/orders',
          component: './Order/Order',
        },
        {
          name: 'payment.subscriptions',
          path: '/payment/subscriptions',
          component: './Order/Order',
        },
      ],
    },
    {
      path: '/product',
      name: 'product',
      routes: [
        {
          name: 'product.products',
          path: '/product/products',
          component: './Product/Product',
        },
      ],
    },
    {
      name: 'dashboard',
      icon: 'table',
      routes: [
        {
          name: 'workbench',
          path: '/dashboard/workbench',
          component: './Welcome',
        },
      ],
    },
    ...extra,
    {
      path: '/',
      redirect: '/dashboard/workbench',
    },
    {
      path: '*',
      component: './404',
    },
  ];
}
