'use client';
import React from 'react';
import { useTheme } from 'next-themes';

const Toggle = () => {
	const { systemTheme, theme, setTheme } = useTheme();
	const currentTheme = theme === 'system' ? systemTheme : theme;

	return (
		<button
			onClick={() => (theme == 'dark' ? setTheme('light') : setTheme('dark'))}
			className='bg-gray-800 dark:bg-gray-50 hover:bg-gray-600 dark:hover:bg-gray-300 transition-all duration-100 text-white dark:text-gray-800 px-6 py-1 text-xl md:text-2xl rounded-md'
		>
			Mode
		</button>
	);
};

export default Toggle;
