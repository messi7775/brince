import type {
    ApiResponse,
    PaginatedResponse,
    PaginationMeta,
} from '@prince-net/types';

/**
 * api-client — Unified HTTP client for Prince Net API.
 *
 * قواعد:
 *  - لا مصادقة، لا CSRF — جميع المسارات عامة.
 *  - معالجة موحّدة للأخطاء مع ApiClientError.
 */

const API_BASE_URL: string =
    import.meta.env.VITE_API_BASE_URL ?? '/api/v1';

// ───────────────────────────────────────────────────────────────
// ApiClientError
// ───────────────────────────────────────────────────────────────
export class ApiClientError extends Error {
    public readonly status: number;
    public readonly code: string;
    public readonly details?: Record<string, unknown>;

    constructor(
        status: number,
        message: string,
        code: string,
        details?: Record<string, unknown>,
    ) {
        super(message);
        this.name = 'ApiClientError';
        this.status = status;
        this.code = code;
        this.details = details;
    }
}

export interface RequestOptions {
    method?: 'GET' | 'POST' | 'PATCH' | 'PUT' | 'DELETE';
    body?: unknown;
    query?: Record<string, string | number | boolean | undefined>;
    signal?: AbortSignal;
}

// ───────────────────────────────────────────────────────────────
// URL builder
// ───────────────────────────────────────────────────────────────
function buildUrl(path: string, query?: RequestOptions['query']): string {
    const cleanPath = path.startsWith('/') ? path.slice(1) : path;
    const base = API_BASE_URL.endsWith('/')
        ? API_BASE_URL.slice(0, -1)
        : API_BASE_URL;

    let fullUrl = `${base}/${cleanPath}`;

    if (query) {
        const params = new URLSearchParams();
        for (const [key, value] of Object.entries(query)) {
            if (value !== undefined && value !== null && value !== '') {
                params.append(key, String(value));
            }
        }
        const qs = params.toString();
        if (qs) fullUrl += `?${qs}`;
    }

    return fullUrl;
}

// ───────────────────────────────────────────────────────────────
// Raw fetch
// ───────────────────────────────────────────────────────────────
interface RawResponse<T> {
    status: number;
    ok: boolean;
    data: T | null;
    errorPayload: {
        message?: string;
        code?: string;
        details?: Record<string, unknown>;
    } | null;
}

async function rawFetch<T>(
    url: string,
    init: RequestInit,
): Promise<RawResponse<T>> {
    const response = await fetch(url, init);

    let payload: unknown = null;
    const contentType = response.headers.get('content-type');
    if (contentType && contentType.includes('application/json')) {
        try {
            payload = await response.json();
        } catch {
            payload = null;
        }
    }

    if (!response.ok) {
        return {
            status: response.status,
            ok: false,
            data: null,
            errorPayload: payload as RawResponse<T>['errorPayload'],
        };
    }

    return {
        status: response.status,
        ok: true,
        data: payload as T,
        errorPayload: null,
    };
}

// ───────────────────────────────────────────────────────────────
// Main request
// ───────────────────────────────────────────────────────────────
async function request<T>(
    path: string,
    options: RequestOptions = {},
): Promise<T> {
    const { method = 'GET', body, query, signal } = options;

    const headers: Record<string, string> = {
        Accept: 'application/json',
    };

    if (body !== undefined) {
        headers['Content-Type'] = 'application/json';
    }

    const url = buildUrl(path, query);
    const init: RequestInit = {
        method,
        headers,
        credentials: 'include',
        body: body !== undefined ? JSON.stringify(body) : undefined,
        signal,
    };

    const result = await rawFetch<T>(url, init);

    if (!result.ok) {
        const err = result.errorPayload;
        throw new ApiClientError(
            result.status,
            err?.message ?? `Request failed with status ${result.status}`,
            err?.code ?? 'HTTP_ERROR',
            err?.details,
        );
    }

    return result.data as T;
}

// ───────────────────────────────────────────────────────────────
// Public helpers
// ───────────────────────────────────────────────────────────────
async function get<T>(
    path: string,
    options?: Omit<RequestOptions, 'method' | 'body'>,
): Promise<T> {
    return request<T>(path, { ...options, method: 'GET' });
}

async function post<T>(
    path: string,
    body?: unknown,
    options?: Omit<RequestOptions, 'method' | 'body'>,
): Promise<T> {
    return request<T>(path, { ...options, method: 'POST', body });
}

async function patch<T>(
    path: string,
    body?: unknown,
    options?: Omit<RequestOptions, 'method' | 'body'>,
): Promise<T> {
    return request<T>(path, { ...options, method: 'PATCH', body });
}

async function del<T>(
    path: string,
    options?: Omit<RequestOptions, 'method' | 'body'>,
): Promise<T> {
    return request<T>(path, { ...options, method: 'DELETE' });
}

export interface PaginatedResult<T> {
    data: T[];
    meta: PaginationMeta;
}

async function getPaginated<T>(
    path: string,
    options?: Omit<RequestOptions, 'method' | 'body'>,
): Promise<PaginatedResult<T>> {
    const response = await request<PaginatedResponse<T>>(path, {
        ...options,
        method: 'GET',
    });
    return { data: response.data, meta: response.meta };
}

export const apiClient = {
    get,
    post,
    patch,
    delete: del,
    getPaginated,
    ApiClientError,
};

export type { ApiResponse };
