import { createParamDecorator, ExecutionContext } from '@nestjs/common';

export interface CurrentUserPayload {
  userId: string;
  email: string;
}

/**
 * @CurrentUser() — يستخرج المستخدم الحالي من request.user
 * (يُضاف بواسطة SystemUserGuard).
 */
export const CurrentUser = createParamDecorator(
  (_data: unknown, ctx: ExecutionContext): CurrentUserPayload => {
    const request = ctx.switchToHttp().getRequest<{ user?: CurrentUserPayload }>();
    return request.user ?? { userId: 'system', email: 'system@prince-net.local' };
  },
);
