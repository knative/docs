'use-client';
import { useState } from 'react';

export default function SubmitButton() {
	const [hover, setHover] = useState(false);

	return (
		<button
			type='submit'
			className={`font-bold py-2 px-9 rounded ${hover ? '' : 'bg-blue-600'}`}
			style={{ backgroundColor: hover ? '#A0DDFF' : '#A5D8FF' }}
			onMouseEnter={() => setHover(true)}
			onMouseLeave={() => setHover(false)}
		>
			Submit
		</button>
	);
}
