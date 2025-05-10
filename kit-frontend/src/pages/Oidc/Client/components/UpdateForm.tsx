import type { ProFormInstance } from '@ant-design/pro-components';
import {
  ProFormText,
  DrawerForm,
  ProFormSelect,
  ProFormSwitch,
  ProFormTextArea,
} from '@ant-design/pro-components';
import { useIntl } from '@umijs/max';
import React, { useEffect, useRef } from 'react';
import type { ClientOAuth2Client } from '@gosaas/api';
import { ClientServiceApi } from '@gosaas/api';

const service = new ClientServiceApi();

export type FormValueType = ClientOAuth2Client;

export type UpdateFormProps = {
  onCancel: (flag?: boolean, formVals?: FormValueType) => void;
  onSubmit: (values: FormValueType) => Promise<void>;
  updateModalVisible: boolean;
  values: FormValueType;
};

const UpdateForm: React.FC<UpdateFormProps> = (props) => {
  const intl = useIntl();
  const formRef = useRef<ProFormInstance>();
  useEffect(() => {
    //fetch  detail
    if (props.values?.clientId && props.updateModalVisible) {
      service.clientServiceGetOAuth2Client({ id: props.values!.clientId! }).then((resp) => {
        formRef?.current?.setFieldsValue(resp.data);
      });
    }
  }, [props]);

  return (
    <DrawerForm
      formRef={formRef}
      initialValues={props.values}
      open={props.updateModalVisible}
      onFinish={async (formData) => {
        console.log(formData);
        const ret = {
          clientId: props.values?.clientId,
          ...formData,
        };
        console.log(ret);
        await props.onSubmit(ret);
      }}
      drawerProps={{
        onClose: () => {
          props.onCancel();
        },
        destroyOnClose: true,
      }}
    >
      <ProFormText
        name="clientName"
        label={intl.formatMessage({
          id: 'oidc.client.name',
          defaultMessage: 'Client Name',
        })}
        rules={[
          {
            required: true,
          },
        ]}
      />
      <ProFormSelect
        name="allowedCorsOrigins"
        mode="tags"
        label={intl.formatMessage({
          id: 'oidc.client.allowedCorsOrigins',
          defaultMessage: 'Client AllowedCorsOrigins',
        })}
      />
      <ProFormSelect
        name="audience"
        mode="tags"
        label={intl.formatMessage({
          id: 'oidc.client.audience',
          defaultMessage: 'Client Audience',
        })}
      />
      <ProFormSwitch
        name="backchannelLogoutSessionRequired"
        label={intl.formatMessage({
          id: 'oidc.client.backchannelLogoutSessionRequired',
          defaultMessage: 'Client BackchannelLogoutSessionRequired',
        })}
      />
      <ProFormSwitch
        name="backchannelLogoutUri"
        label={intl.formatMessage({
          id: 'oidc.client.backchannelLogoutUri',
          defaultMessage: 'Client BackchannelLogoutUri',
        })}
      />
      <ProFormText
        name="clientSecret"
        label={intl.formatMessage({
          id: 'oidc.client.clientSecret',
          defaultMessage: 'Client ClientSecret',
        })}
      />
      <ProFormText
        name="clientUri"
        label={intl.formatMessage({
          id: 'oidc.client.clientUri',
          defaultMessage: 'Client ClientUri',
        })}
      />
      <ProFormTextArea
        name="contacts"
        convertValue={(value: any) => {
          if (value && Array.isArray(value) && value.length > 0) {
            return value[0];
          } else {
            return undefined;
          }
        }}
        transform={(value) => {
          if (value && Array.isArray(value)) {
            return { contacts: value };
          }
          return { contacts: value ? [value] : undefined };
        }}
        label={intl.formatMessage({
          id: 'oidc.client.contacts',
          defaultMessage: 'Client Contacts',
        })}
      />
      <ProFormSwitch
        name="frontchannelLogoutSessionRequired"
        label={intl.formatMessage({
          id: 'oidc.client.FrontchannelLogoutSessionRequired',
          defaultMessage: 'Client FrontchannelLogoutSessionRequired',
        })}
      />
      <ProFormSwitch
        name="frontchannelLogoutUri"
        label={intl.formatMessage({
          id: 'oidc.client.frontchannelLogoutUri',
          defaultMessage: 'Client FrontchannelLogoutUri',
        })}
      />
      <ProFormSelect
        name="grantTypes"
        mode="tags"
        label={intl.formatMessage({
          id: 'oidc.client.grantTypes',
          defaultMessage: 'Client GrantTypes',
        })}
        valueEnum={{
          authorization_code: 'authorization_code',
          implicit: 'implicit',
          client_credentials: 'client_credentials',
          refresh_token: 'refresh_token',
        }}
      />
      <ProFormText
        name="owner"
        label={intl.formatMessage({
          id: 'oidc.client.owner',
          defaultMessage: 'Client Owner',
        })}
      />
      <ProFormText
        name="policyUri"
        label={intl.formatMessage({
          id: 'oidc.client.policyUri',
          defaultMessage: 'Client PolicyUri',
        })}
      />
      <ProFormSelect
        name="postLogoutRedirectUris"
        mode="tags"
        label={intl.formatMessage({
          id: 'oidc.client.postLogoutRedirectUris',
          defaultMessage: 'Client PostLogoutRedirectUris',
        })}
      />
      <ProFormSelect
        name="redirectUris"
        mode="tags"
        label={intl.formatMessage({
          id: 'oidc.client.redirectUris',
          defaultMessage: 'Client RedirectUris',
        })}
      />
      <ProFormText
        name="registrationAccessToken"
        label={intl.formatMessage({
          id: 'oidc.client.registrationAccessToken',
          defaultMessage: 'Client RegistrationAccessToken',
        })}
      />
      <ProFormText
        name="registrationClientUri"
        label={intl.formatMessage({
          id: 'oidc.client.registrationClientUri',
          defaultMessage: 'Client RegistrationClientUri',
        })}
      />
      <ProFormText
        name="requestObjectSigningAlg"
        label={intl.formatMessage({
          id: 'oidc.client.requestObjectSigningAlg',
          defaultMessage: 'Client RequestObjectSigningAlg',
        })}
      />
      <ProFormSelect
        name="requestUris"
        mode="tags"
        label={intl.formatMessage({
          id: 'oidc.client.requestUris',
          defaultMessage: 'Client RequestUris',
        })}
      />
      <ProFormSelect
        name="responseTypes"
        mode="tags"
        label={intl.formatMessage({
          id: 'oidc.client.responseTypes',
          defaultMessage: 'Client ResponseTypes',
        })}
        valueEnum={{
          code: 'code',
          'code id_token': 'code id_token',
          id_token: 'id_token',
          'token id_token': 'token id_token',
          token: 'token',
          'token id_token code': 'token id_token code',
        }}
      />
      <ProFormText
        name="scope"
        label={intl.formatMessage({
          id: 'oidc.client.scope',
          defaultMessage: 'Client Scope',
        })}
        tooltip="offline_access offline openid"
      />
      <ProFormSelect
        name="subjectType"
        label={intl.formatMessage({
          id: 'oidc.client.subjectType',
          defaultMessage: 'Client SubjectType',
        })}
        valueEnum={{
          pairwise: 'pairwise',
          public: 'public',
        }}
      />
      <ProFormSelect
        name="tokenEndpointAuthMethod"
        label={intl.formatMessage({
          id: 'oidc.client.tokenEndpointAuthMethod',
          defaultMessage: 'Client TokenEndpointAuthMethod',
        })}
        valueEnum={{
          client_secret_post: 'client_secret_post',
          client_secret_basic: 'client_secret_basic',
          private_key_jwt: 'private_key_jwt',
          none: 'none',
        }}
      />
      <ProFormText
        name="tokenEndpointAuthSigningAlg"
        label={intl.formatMessage({
          id: 'oidc.client.tokenEndpointAuthSigningAlg',
          defaultMessage: 'Client TokenEndpointAuthSigningAlg',
        })}
      />
      <ProFormText
        name="tosUri"
        label={intl.formatMessage({
          id: 'oidc.client.tosUri',
          defaultMessage: 'Client TosUri',
        })}
      />
      <ProFormSelect
        name="userinfoSignedResponseAlg"
        label={intl.formatMessage({
          id: 'oidc.client.userinfoSignedResponseAlg',
          defaultMessage: 'Client UserinfoSignedResponseAlg',
        })}
        valueEnum={{
          none: 'none',
          RS256: 'RS256',
        }}
      />
    </DrawerForm>
  );
};

export default UpdateForm;
