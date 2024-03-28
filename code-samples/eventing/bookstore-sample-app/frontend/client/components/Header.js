import Image from 'next/image';
import Toggle from './Toggle';

const Header = () => {
	return (
		<div className='flex justify-between p-4'>
			<header className='flex items-center p-4'>
				<Image
					src='/images/knative-logo.png'
					alt='Knative BookStore Logo'
					width={50}
					height={50}
					className='mr-2'
				/>
				<h1 className='text-3xl font-bold'>Knative BookStore</h1>
			</header>
			<Toggle />
		</div>
	);
};

export default Header;
