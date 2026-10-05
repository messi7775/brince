import { Link } from 'react-router-dom';
import { Menu } from 'lucide-react';
import { Button } from '../ui/button';
import { ThemeToggle } from './ThemeToggle';
import { Breadcrumbs } from '../navigation/Breadcrumbs';
import { NotificationCenter } from '../../features/notifications/components/NotificationCenter';

interface HeaderProps {
  onMenuClick: () => void;
}

export function Header({ onMenuClick }: HeaderProps) {
  return (
    <header className="sticky top-0 z-40 h-16 border-b bg-card">
      <div className="flex h-full items-center justify-between gap-4 px-4">
        {/* Start: Menu + Logo + Breadcrumbs */}
        <div className="flex items-center gap-3 min-w-0 flex-1">
          <Button
            variant="ghost"
            size="icon"
            className="lg:hidden shrink-0"
            onClick={onMenuClick}
            aria-label="فتح القائمة"
          >
            <Menu className="h-5 w-5" />
          </Button>

          <Link to="/dashboard" className="flex items-center gap-2 shrink-0">
            <span className="text-lg font-bold tracking-tight sm:text-xl">
              البرنس نت
            </span>
          </Link>

          <Breadcrumbs className="ms-4" />
        </div>

        {/* End: Theme + Notifications */}
        <div className="flex items-center gap-2 shrink-0">
          <NotificationCenter />
          <ThemeToggle />
        </div>
      </div>
    </header>
  );
}
