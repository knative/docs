import type { Config } from 'tailwindcss';

const config: Config = {
	content: [
		'./client/pages/**/*.{js,ts,jsx,tsx,mdx}',
		'./client/components/**/*.{js,ts,jsx,tsx,mdx}',
		'./app/**/*.{js,ts,jsx,tsx,mdx}',
	],
	theme: {
		extend: {
			backgroundImage: {
				'gradient-radial': 'radial-gradient(var(--tw-gradient-stops))',
				'gradient-conic':
					'conic-gradient(from 180deg at 50% 50%, var(--tw-gradient-stops))',
			},
			fontFamily: {
				sans: ['Poppins', 'sans-serif'],
			},
		},
	},
	darkMode: 'class',
	plugins: [],
};
export default config;
