import {
  CanActivate,
  ExecutionContext,
  Injectable,
} from '@nestjs/common';

interface SystemUser {
  userId: string;
  email: string;
}

/**
 * SystemUserGuard — لا يتطلب مصادقة.
 *
 * لا يستعلم قاعدة البيانات — يضع مستخدم نظام ثابت
 * لاستخدامه في سجلات التدقيق وحقول createdBy/cancelledBy.
 *
 * جميع المسارات عامة — لا JWT، لا CSRF، لا تسجيل دخول.
 */
@Injectable()
export class SystemUserGuard implements CanActivate {
  private static readonly SYSTEM_USER: SystemUser = {
    userId: 'system',
    email: 'system@prince-net.local',
  };

  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest<{
      user?: SystemUser;
    }>();

    request.user = SystemUserGuard.SYSTEM_USER;
    return true;
  }
}
