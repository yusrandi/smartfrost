import React, { useState, type ReactNode } from 'react';
import { Sidebar } from './Sidebar';
import { TopHeader } from './TopHeader';
import { Footer } from './Footer';

interface AppLayoutProps {
  children: ReactNode;
  activeTab: string;
  onTabChange: (tabId: string) => void;
  currentTabLabel: string;
}

export const AppLayout: React.FC<AppLayoutProps> = ({
  children,
  activeTab,
  onTabChange,
  currentTabLabel,
}) => {
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);

  return (
    <div className="flex min-h-screen bg-[#F4F7F9] text-slate-800 antialiased font-sans">
      {/* Sidebar Navigation (Desktop fixed + Mobile off-canvas drawer) */}
      <Sidebar
        activeTab={activeTab}
        onTabChange={onTabChange}
        isMobileOpen={isMobileMenuOpen}
        onCloseMobile={() => setIsMobileMenuOpen(false)}
      />

      {/* Main Content Area */}
      <div className="flex flex-1 flex-col min-w-0 overflow-x-hidden">
        {/* Top Navbar / Header with Mobile Hamburger Menu */}
        <TopHeader
          currentTabLabel={currentTabLabel}
          onNavigateProfile={() => onTabChange('profile')}
          onToggleMobileMenu={() => setIsMobileMenuOpen(!isMobileMenuOpen)}
        />

        {/* Page Main Content with responsive padding */}
        <main className="flex-1 p-3.5 sm:p-5 md:p-6 lg:p-8 min-w-0">
          {children}
        </main>

        {/* Global Footer */}
        <Footer />
      </div>
    </div>
  );
};
