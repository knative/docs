'use client';
import Main from '../client/pages/Main';
import { ThemeProvider } from 'next-themes';

export default function Home() {
	return (
		<ThemeProvider attribute='class'>
			<Main />
		</ThemeProvider>
	);
}
