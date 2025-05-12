export const ErrorShowType = {
  SILENT: 0,
  WARN_MESSAGE: 1,
  ERROR_MESSAGE: 2,
  NOTIFICATION: 4,
  REDIRECT: 9,
};

// Define los tipos que faltan
export type RequestInterceptor = (url: string, options: RequestConfig) => {
  url?: string;
  options?: RequestConfig;
};

export type ResponseInterceptor = (response: Response, options: RequestConfig) => Response;

export interface RequestOptions {
  skipErrorHandler?: boolean;
}

export interface RequestConfig extends RequestInit {
  errorConfig?: {
    errorPage?: string;
    adaptor?: (resData: any, ctx: any) => ErrorInfoType;
  };
  requestInterceptors?: RequestInterceptor[];
  responseInterceptors?: ResponseInterceptor[];
}

export interface ErrorInfoType {
  success: boolean;
  data?: any;
  errorCode?: string;
  errorMessage?: string;
  showType?: number;
  traceId?: string;
  host?: string;
}
