import { PlusOutlined } from '@ant-design/icons';
import type {
  ActionType,
  ProColumnType,
  ProDescriptionsItemProps,
} from '@ant-design/pro-components';
import {
  PageContainer,
  ProDescriptions,
  ProTable,
  TableDropdown,
} from '@ant-design/pro-components';
import { FormattedMessage } from '@umijs/max';
import { Button, Drawer, message } from 'antd';
import React, { useRef, useState } from 'react';
import UpdateForm from './components/UpdateForm';
import { requestTransform } from '@gosaas/core';
import type {
  V1CreateMenuRequest,
  V1UpdateMenu,
  MenuServiceUpdateMenuRequest,
  V1Menu,
  V1MenuFilter,
} from '@gosaas/api';
import { MenuServiceApi } from '@gosaas/api';
import * as allIcons from '@ant-design/icons';
import { useIntl } from '@umijs/max';
import type { MenuWithChildren } from './data';
import { getTreeData } from './data';

const TableList: React.FC = () => {
  const [updateModalVisible, handleUpdateModalVisible] = useState<boolean>(false);
  const [defaultExpanded, setDefaultExpanded] = useState<React.Key[]>([]);
  const [showDetail, setShowDetail] = useState<boolean>(false);

  const actionRef = useRef<ActionType>();
  const [currentRow, setCurrentRow] = useState<MenuWithChildren | undefined | null>(undefined);

  const intl = useIntl();
  const handleAdd = async (fields: V1CreateMenuRequest) => {
    const hide = message.loading(
      intl.formatMessage({ id: 'common.creating', defaultMessage: 'Creating...' }),
    );
    try {
      await new MenuServiceApi().menuServiceCreateMenu({ body: fields });
      hide();
      message.success(
        intl.formatMessage({ id: 'common.created', defaultMessage: 'Created Successfully' }),
      );
      return true;
    } catch (error) {
      hide();
      return false;
    }
  };

  const handleUpdate = async (fields: MenuServiceUpdateMenuRequest) => {
    const hide = message.loading(
      intl.formatMessage({ id: 'common.updating', defaultMessage: 'Updating...' }),
    );
    try {
      await new MenuServiceApi().menuServiceUpdateMenu2({ body: fields, menuId: currentRow!.id! });
      hide();
      message.success(
        intl.formatMessage({ id: 'common.updated', defaultMessage: 'Update Successfully' }),
      );
      return true;
    } catch (error) {
      hide();
      return false;
    }
  };

  const handleRemove = async (selectedRow: V1Menu) => {
    const hide = message.loading(
      intl.formatMessage({ id: 'common.deleting', defaultMessage: 'Deleting...' }),
    );
    try {
      await new MenuServiceApi().menuServiceDeleteMenu({ id: selectedRow.id! });
      message.success(
        intl.formatMessage({ id: 'common.deleted', defaultMessage: 'Delete Successfully' }),
      );
      return true;
    } catch (error) {
      return false;
    } finally {
      hide();
    }
  };

  const columns: ProColumnType<MenuWithChildren>[] = [
    {
      title: <FormattedMessage id="sys.menu.icon" defaultMessage="Menu Icon" />,
      dataIndex: 'icon',
      render: (dom, entity) => {
        const icon = entity.icon ?? 'AppstoreOutlined';
        return React.createElement(allIcons[icon] || allIcons.AppstoreOutlined);
      },
      width: 120,
    },
    {
      title: <FormattedMessage id="sys.menu.name" defaultMessage="Menu Name" />,
      dataIndex: 'name',
      render: (dom, entity) => {
        return (
          <a
            onClick={() => {
              setCurrentRow(entity);
              setShowDetail(true);
            }}
          >
            {dom}
          </a>
        );
      },
    },
    {
      title: <FormattedMessage id="sys.menu.title" defaultMessage="Menu Title" />,
      dataIndex: 'title',
      valueType: 'text',
      ellipsis: true,
      render: (dom, entity) => {
        return (
          <FormattedMessage
            id={entity.title || entity.name}
            defaultMessage={entity.title || entity.name}
          />
        );
      },
    },
    {
      title: <FormattedMessage id="sys.menu.path" defaultMessage="Route Path" />,
      dataIndex: 'path',
      valueType: 'text',
    },
    {
      title: <FormattedMessage id="sys.menu.priority" defaultMessage="Priority" />,
      dataIndex: 'priority',
      valueType: 'digit',
    },
    {
      title: <FormattedMessage id="sys.menu.ignoreAuth" defaultMessage="Ignore Auth" />,
      dataIndex: 'ignoreAuth',
      valueType: 'switch',
    },
    {
      title: <FormattedMessage id="sys.menu.iframe" defaultMessage="iframe" />,
      dataIndex: 'iframe',
      valueType: 'text',
    },
    {
      title: <FormattedMessage id="sys.menu.microAppName" defaultMessage="MicroApp Name" />,
      dataIndex: 'microAppName',
      valueType: 'text',
    },
    {
      title: <FormattedMessage id="sys.menu.microApp" defaultMessage="MicroApp" />,
      dataIndex: 'microApp',
      valueType: 'text',
      ellipsis: true,
    },
    {
      title: (
        <FormattedMessage id="sys.menu.microAppDev" defaultMessage="MicroApp For Development" />
      ),
      dataIndex: 'microAppDev',
      valueType: 'text',
      ellipsis: true,
    },
    {
      title: (
        <FormattedMessage id="sys.menu.microAppBaseRoute" defaultMessage="MicroApp Base Route" />
      ),
      dataIndex: 'microAppBaseRoute',
      valueType: 'text',
      ellipsis: true,
    },
    {
      title: <FormattedMessage id="pages.searchTable.titleOption" defaultMessage="Operating" />,
      key: 'option',
      valueType: 'option',
      width: 180,
      render: (_, record) => [
        <a
          key="editable"
          onClick={() => {
            setCurrentRow(record);
            setShowDetail(false);
            handleUpdateModalVisible(true);
          }}
        >
          <FormattedMessage id="pages.searchTable.edit" defaultMessage="Edit" />
        </a>,
        <TableDropdown
          key="actionGroup"
          onSelect={async (key) => {
            if (key === 'delete') {
              const ok = await handleRemove(record);
              if (ok && actionRef.current) {
                actionRef.current.reload();
              }
            }
          }}
          menus={[
            {
              key: 'delete',
              name: <FormattedMessage id="common.delete" defaultMessage="Delete" />,
            },
          ]}
        />,
      ],
    },
  ];

  const getData = requestTransform<MenuWithChildren, V1MenuFilter>(async () => {
    const newExpandedKeys: string[] = [];
    const render = (treeDatas: MenuWithChildren[]) => {
      // 获取到所有可展开的父节点
      treeDatas.forEach((item) => {
        if (item.children) {
          newExpandedKeys.push(item.id!);
          render(item.children);
        }
      });
      return newExpandedKeys;
    };
    const tree = await getTreeData();
    setDefaultExpanded(render(tree));

    return {
      items: tree,
    };
  });

  return (
    <PageContainer>
      <ProTable<MenuWithChildren>
        actionRef={actionRef}
        rowKey="id"
        search={false}
        pagination={false}
        toolBarRender={() => [
          <Button
            type="primary"
            key="primary"
            onClick={() => {
              setCurrentRow(undefined);
              handleUpdateModalVisible(true);
            }}
          >
            <PlusOutlined /> <FormattedMessage id="pages.searchTable.new" defaultMessage="New" />
          </Button>,
        ]}
        type="table"
        request={getData}
        expandable={{
          expandedRowKeys: defaultExpanded,
          onExpandedRowsChange: (keys) => {
            setDefaultExpanded(keys.map((p) => p));
          },
          indentSize: 20,
        }}
        columns={columns}
      />
      <UpdateForm
        onSubmit={async (value) => {
          const { id } = value;
          let success = false;
          if (id) {
            success = await handleUpdate({ menu: value as V1UpdateMenu });
          } else {
            success = await handleAdd(value as V1CreateMenuRequest);
          }

          if (success) {
            handleUpdateModalVisible(false);
            setCurrentRow(undefined);
            if (actionRef.current) {
              actionRef.current.reload();
            }
          }
        }}
        onCancel={() => {
          handleUpdateModalVisible(false);
          if (!showDetail) {
            setCurrentRow(undefined);
          }
        }}
        updateModalVisible={updateModalVisible}
        values={currentRow || {}}
      />
      <Drawer
        width={600}
        open={showDetail}
        onClose={() => {
          setCurrentRow(undefined);
          setShowDetail(false);
        }}
        closable={false}
        destroyOnClose
      >
        {currentRow?.name && (
          <ProDescriptions<V1Menu>
            column={2}
            title={currentRow?.name}
            request={async () => ({
              data: currentRow || {},
            })}
            params={{
              id: currentRow?.name,
            }}
            columns={columns as ProDescriptionsItemProps<V1Menu>[]}
          />
        )}
      </Drawer>
    </PageContainer>
  );
};

export default TableList;
