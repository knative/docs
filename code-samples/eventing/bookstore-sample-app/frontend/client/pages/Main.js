'use client';
import Header from '../components/Header';
import BookDetail from '../components/BookDetail';
import CommentForm from '../components/CommentForm';
import CommentList from '../components/CommentList';
import { ThemeProvider } from 'next-themes';

export default function Main() {
	/* Example Book object */
	const book = {
		img: '/images/Bookcover.jpg',
		title: 'Building serverless applications on Knative',
		author: 'Evan Anderson',
		ISBN: '978-1098142070',
		publisher: 'Oreilly & Associates Inc',
		publishedDate: 'December 19, 2023',
		description:
			'A Guide to Designing and Writing Serverless Cloud Application',
		price: '$49',
	};
	return (
		<div>
			<Header />

			<main className='container mx-auto my-8'>
				<BookDetail book={book} />
				<CommentForm />
				<CommentList />
			</main>
		</div>
	);
}
