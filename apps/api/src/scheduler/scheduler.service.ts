import { Injectable, Logger } from '@nestjs/common';
import { Cron } from '@nestjs/schedule';
import { BackupsService } from '../backups/backups.service';

/**
 * المهام المجدولة (كل التوقيتات UTC).
 *
 *  - نسخة احتياطية كاملة تلقائية كل يوم جمعة منتصف الليل.
 *    createdBy تُنسب لمستخدم النظام لأن العملية
 *    تعمل خارج أي جلسة HTTP.
 */
@Injectable()
export class SchedulerService {
  private readonly logger = new Logger(SchedulerService.name);

  constructor(
    private readonly backupsService: BackupsService,
  ) {}

  /** نسخة احتياطية أسبوعية — الجمعة 00:00 UTC */
  @Cron('0 0 * * 5', { name: 'weekly-backup', timeZone: 'UTC' })
  async weeklyBackup(): Promise<void> {
    try {
      const backup = await this.backupsService.create('system', {
        userAgent: 'prince-net-scheduler',
      });
      this.logger.log(
        `النسخة الأسبوعية أُنشئت: ${backup.fileName} (${backup.recordCount} سجل)`,
      );
    } catch (err) {
      this.logger.error(
        `فشل النسخ الاحتياطي الأسبوعي: ${
          err instanceof Error ? err.message : String(err)
        }`,
      );
    }
  }
}
