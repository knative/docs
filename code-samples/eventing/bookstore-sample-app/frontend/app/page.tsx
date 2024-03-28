'use client';
import Image from 'next/image';
import Main from '../client/pages/Main';
// import { keepTheme } from '../client/utils/themes';
import { useEffect } from 'react';
import { ThemeProvider } from 'next-themes';

export default function Home() {
	return (
		<ThemeProvider>
			<Main />
		</ThemeProvider>
	);
}
