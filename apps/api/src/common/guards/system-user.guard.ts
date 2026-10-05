import {
  CanActivate,
  ExecutionContext,
  Injectable,
  Logger,
} from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

interface SystemUser {
  userId: string;
  email: string;
}

/**
 * SystemUserGuard — لا يتطلب مصادقة.
 *
 * يحلّ المستخدم الإداري الأول من قاعدة البيانات (المُنشأ عبر الـ seed)
 * ويضعه في request.user لاستخدامه في سجلات التدقيق وحقول createdBy/cancelledBy.
 * النتيجة تُخزَّن مؤقتًا بعد أول طلب (لا استعلام DB متكرر).
 *
 * جميع المسارات عامة — لا JWT، لا CSRF، لا تسجيل دخول.
 */
@Injectable()
export class SystemUserGuard implements CanActivate {
  private readonly logger = new Logger(SystemUserGuard.name);
  private cached: SystemUser | null = null;

  constructor(private readonly prisma: PrismaService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest<{
      user?: SystemUser;
    }>();

    if (!this.cached) {
      const user = await this.prisma.user.findFirst({
        orderBy: { createdAt: 'asc' },
        select: { id: true, email: true },
      });
      if (user) {
        this.cached = { userId: user.id, email: user.email };
      } else {
        this.logger.warn('No user found in database — audit logs will be skipped');
      }
    }

    request.user = this.cached ?? undefined;
    return true;
  }
}
